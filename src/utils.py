def mirror_word(word):
    return ''.join(
        c.lower() if c.isupper() else c.upper() if c.islower() else c
        for c in word
    )[::-1]