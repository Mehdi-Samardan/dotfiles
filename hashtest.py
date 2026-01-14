#!/usr/bin/env python3
from hashlib import sha256

FILENAME = "/Users/mehdi/Documents/GitHub/dotfiles/Presentation1.pptx"   # <-- buraya dosya adını yaz

def sha256sum(filename):
    h = sha256()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

if __name__ == "__main__":
    print(sha256sum(FILENAME))


# 1-> ba1b2558b642a82fec3cace0d50f6e60044e729d1fff89391c95d64c22e4a580
# 2-> ed345cefbc6140c7c1d6d91bd560c08ef5f8ca93acbcf011f405669297cf3e02
# 3-> eea103a71c1222a9e6ac90e26b37de73229c6aeb245ad573d5ea3960d5caf7f2
# 4-> eea103a71c1222a9e6ac90e26b37de73229c6aeb245ad573d5ea3960d5caf7f2  (Nothing changed form 3)
# 5-> efde77f7f986b34b5a8d9e050b91f6a7544458ffd7cb41e7c69c65be0b8f78bf  (Not changed but saved again)
