import os
import logging
from avtomat_aws import sts, ec2, s3, cloudtrail, general

logging.basicConfig(level=logging.WARNING,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """Lambda function entry point"""

    threshold_days = event['vars']['threshold_days']
    wait_before_delete_days = event['vars']['wait_before_delete_days']
    regions = event['vars']['regions']
    exclude_tags = event['vars']['exclude_tags']
    bucket_name = event['vars']['bucket_name']
    account = event['account']
    role_name = os.environ['SERVICE_ROLE_NAME']

    logger.info(f"Checking account: {account}")

    detached_before = general.get_date(before=threshold_days, format='iso')
    grace_period = general.get_date(before=wait_before_delete_days, format='string')

    role_arn = f'arn:aws:iam::{account}:role/{role_name}'
    session = sts.create_session(role_arn=role_arn)

    active_regions = ec2.discover_active_regions(session=session)

    for region in regions:

        logger.info(f"Checking region: {region}")

        # Skip supplied region if it's not active
        if region not in active_regions:
            logger.warning(f"Region {region} is not active, skipping")
            continue

        logger.info(f"Retrieving volumes that don't have any exclusion tags")
        volumes_to_evaluate = ec2.discover_tags(resource_types=['volume'], tags=exclude_tags,
                                                missing=True, session=session, region=region)

        logger.info(f"Detecting volumes detached for longer period than the threshold")
        volumes = []
        if volumes_to_evaluate:
            for volume in volumes_to_evaluate:
                events = cloudtrail.discover_resource_events(resource_id=volume, events=['DetachVolume'],
                                                             silent=True, session=session, region=region)
                if events and events[0]['EventTime'] < detached_before:
                    volumes.append(volume)
                elif not events:
                    logger.warning(f"No 'DetachVolume' CloudTrail events found for {volume}")
        else:
            logger.info("No volumes detected")

        logger.info("Retrieving volumes that are scheduled for deletion")
        scheduled_for_deletion = s3.discover_objects(bucket=bucket_name,
                                                     prefix=f'{account}/{region}/ec2-volumes/',
                                                     name_only=True)

        logger.info("Removing volumes that were scheduled for deletion but are no longer detected")
        # Use case: manually deleted or an exclusion tag was added
        no_longer_detected = list(set(scheduled_for_deletion) - set(volumes))
        s3.delete_objects(bucket=bucket_name, prefix=f'{account}/{region}/ec2-volumes',
                          objects=no_longer_detected)

        logger.info("Retrieving volumes that are ready to delete")
        ready_to_delete = s3.discover_objects(bucket=bucket_name,
                                              prefix=f'{account}/{region}/ec2-volumes/',
                                              modified_before=grace_period,
                                              name_only=True)

        logger.info("Deleting volumes")
        detected_and_ready = list(set(ready_to_delete) & set(volumes))
        ec2.delete_volumes(volume_ids=detected_and_ready, snapshot=True, session=session, region=region)
        s3.delete_objects(bucket=bucket_name, prefix=f'{account}/{region}/ec2-volumes',
                          objects=detected_and_ready)

        logger.info("Scheduling newly detected volumes for deletion")
        newly_detected = list(set(volumes) - set(scheduled_for_deletion))
        objects = [{'Key': obj, 'Body': ''} for obj in newly_detected]
        s3.create_objects(bucket=bucket_name, prefix=f'{account}/{region}/ec2-volumes',
                          objects=objects)

        logger.info(f"Checked region: {region}")

    return {
        'statusCode': 200,
        'body': 'Success'
    }