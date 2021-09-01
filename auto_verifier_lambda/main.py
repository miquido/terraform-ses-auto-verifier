import requests
import s3_notification_to_path
import s3_read_file
import find_verify_link


def lambda_handler(event, context):
    s3_keys = s3_notification_to_path.get_paths(event)
    ses_messages = s3_read_file.s3_read(s3_keys)
    links = find_verify_link.find_verify_link(ses_messages)
    for link in links:
        print(link)
        print(f'stripped = {link.strip()}')
        res = requests.get(link.strip())
        print(res.text)
