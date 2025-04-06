import random
import string


def generate_random_username(length: int = 6, prefix: str = "User") -> str:
    """
    Function that generates a random username
    """
    ret = f"{prefix}-{''.join(random.choices(string.ascii_lowercase + string.digits, k=length))}"
    if len(ret) > 50:
        raise Exception("Max length of accountname exceeded.")
    return ret
