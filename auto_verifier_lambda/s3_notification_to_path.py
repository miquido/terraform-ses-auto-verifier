def get_paths(notification):
    return list(map(lambda r: r['s3']['object']['key'], notification['Records']))
