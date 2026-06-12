import os

def main():
    # Read environment variable:
    participant_name = os.getenv('PARTICIPANT_NAME', "Guest")

    # Print Message
    print(f"Hello {participant_name} from EKS application")

if __name__ == "__main__":
    main()