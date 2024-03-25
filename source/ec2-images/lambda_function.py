import os
import logging
from avtomat_aws import iam, sts, ec2, s3, general

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

    created_before = general.get_date(before=threshold_days)
    grace_period = general.get_date(before=wait_before_delete_days)

    role_arn = f'arn:aws:iam::{account}:role/{role_name}'
    session = sts.create_session(role_arn=role_arn)

    active_regions = ec2.discover_active_regions(session=session)

    for region in regions:

        logger.info(f"Checking region: {region}")

        # Skip supplied region if it's not active
        if region not in active_regions:
            logger.warning(f"Region {region} is not active, skipping")
            continue

        logger.info(f"Retrieving images that don't have any exclusion tags")
        images_to_evaluate = ec2.discover_tags(resource_types=['image'], tags=exclude_tags,
                                               missing=True, session=session, region=region)

        logger.info(f"Evaluating images that are older than the threshold")
        if images_to_evaluate:
            images = ec2.discover_images(image_ids=images_to_evaluate, exclude_aws_backups=True,
                                         created_before=created_before, created_after=cutoff_date,
                                         session=session, region=region)
        else:
            logger.info("No images to evaluate")
            images = []

        logger.info("Retrieving images that are scheduled for deletion")
        scheduled_for_deletion = s3.discover_objects(bucket=bucket_name,
                                                     prefix=f'{account}/{region}/ec2-images/',
                                                     name_only=True)

        logger.info("Removing images that were scheduled for deletion but are no longer detected")
        # Use case: manually deleted or an exclusion tag was added
        no_longer_detected = list(set(scheduled_for_deletion) - set(images))
        s3.delete_objects(bucket=bucket_name, prefix=f'{account}/{region}/ec2-images',
                          objects=no_longer_detected)

        logger.info("Retrieving images that are ready to delete")
        ready_to_delete = s3.discover_objects(bucket=bucket_name,
                                              prefix=f'{account}/{region}/ec2-images/',
                                              modified_before=grace_period,
                                              name_only=True)

        logger.info("Deleting images")
        detected_and_ready = list(set(ready_to_delete) & set(images))
        ec2.delete_images(image_ids=detected_and_ready, include_snapshots=True, session=session, region=region)
        s3.delete_objects(bucket=bucket_name, prefix=f'{account}/{region}/ec2-images',
                          objects=detected_and_ready)

        logger.info("Scheduling newly detected images for deletion")
        newly_detected = list(set(images) - set(scheduled_for_deletion))
        objects = [{'Key': obj, 'Body': ''} for obj in newly_detected]
        s3.create_objects(bucket=bucket_name, prefix=f'{account}/{region}/ec2-images',
                          objects=objects)

        logger.info(f"Checked region: {region}")

    return {
        'statusCode': 200,
        'body': 'Success'
    }