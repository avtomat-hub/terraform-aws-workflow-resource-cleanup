import os
import logging
from avtomat_aws import sts, ec2, s3, general

logging.basicConfig(level=logging.WARNING,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """Lambda function entry point"""

    threshold_days = event['vars']['threshold_days']
    wait_before_delete_days = event['vars']['wait_before_delete_days']
    cutoff_date = event['vars']['cutoff_date']
    regions = event['vars']['regions']
    exclude_tags = event['vars']['exclude_tags']
    bucket_name = event['vars']['bucket_name']
    account = event['account']
    role_name = os.environ['SERVICE_ROLE_NAME']

    logger.info(f"Checking account: {account}")

    created_before = general.get_date(before=threshold_days, format='string')
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

        logger.info("Retrieving snapshots that don't have any exclusion tags")
        snapshots_to_evaluate = ec2.discover_tags(resource_types=['snapshot'], tags=exclude_tags,
                                                  missing=True, session=session, region=region)

        logger.info("Detecting snapshots that are older than the threshold")
        if snapshots_to_evaluate:
            snapshots = ec2.discover_snapshots(snapshot_ids=snapshots_to_evaluate, exclude_aws_backup=True,
                                               created_before=created_before, created_after=cutoff_date,
                                               session=session, region=region)
        else:
            logger.info("No snapshots detected")
            snapshots = []

        logger.info("Retrieving snapshots that are scheduled for deletion")
        scheduled_for_deletion = s3.discover_objects(bucket=bucket_name,
                                                     prefix=f'{account}/{region}/ec2-snapshots/',
                                                     name_only=True)

        logger.info("Removing snapshots that were scheduled for deletion but are no longer detected")
        # Use case: manually deleted or an exclusion tag was added
        no_longer_detected = list(set(scheduled_for_deletion) - set(snapshots))
        s3.delete_objects(bucket=bucket_name, prefix=f'{account}/{region}/ec2-snapshots',
                          objects=no_longer_detected)

        logger.info("Retrieving snapshots that are ready to delete")
        ready_to_delete = s3.discover_objects(bucket=bucket_name,
                                              prefix=f'{account}/{region}/ec2-snapshots/',
                                              modified_before=grace_period,
                                              name_only=True)

        logger.info("Deleting snapshots")
        detected_and_ready = list(set(ready_to_delete) & set(snapshots))
        ec2.delete_snapshots(snapshot_ids=detected_and_ready, session=session, region=region)
        s3.delete_objects(bucket=bucket_name, prefix=f'{account}/{region}/ec2-snapshots',
                          objects=detected_and_ready)

        logger.info("Scheduling newly detected snapshots for deletion")
        newly_detected = list(set(snapshots) - set(scheduled_for_deletion))
        objects = [{'Key': obj, 'Body': ''} for obj in newly_detected]
        s3.create_objects(bucket=bucket_name, prefix=f'{account}/{region}/ec2-snapshots',
                          objects=objects)

        logger.info(f"Checked region: {region}")

    return {
        'statusCode': 200,
        'body': 'Done'
    }
