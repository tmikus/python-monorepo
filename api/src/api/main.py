from utils.get_greeting import get_greeting


def main():
    name = input("What's your name: ")
    print(get_greeting(name))
