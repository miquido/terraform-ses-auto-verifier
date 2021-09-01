import re

regex = r"https://email-verification\..+\.amazonaws.com.*$"


def email_to_link(email: str):
    matches = re.finditer(regex, email, re.MULTILINE)

    for matchNum, match in enumerate(matches, start=1):
        return match.group()


def find_verify_link(emails: [str]):
    return list(map(email_to_link, emails))
