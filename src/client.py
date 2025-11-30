import socket
import json
import logging
import sys

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

SERVER_HOST = 'localhost'
SERVER_PORT = 5555


class ArithmeticClient:
    
    def __init__(self, host: str, port: int):
        self.host = host
        self.port = port
        logger.info(f"Initializing Arithmetic Client (Server: {host}:{port})")
    
    def get_user_input(self) -> dict:
        print(f"\n{'='*60}")
        print("Arithmetic Calculator Client")
        print(f"{'='*60}")
        
        try:
            while True:
                try:
                    num1_input = input("Enter first number: ").strip()
                    num1 = float(num1_input)
                    logger.info(f"User entered first number: {num1}")
                    break
                except ValueError:
                    print("❌ Invalid input. Please enter a valid number.")
            
            print("\nAvailable operations: +, -, *, /")
            while True:
                operation = input("Enter operation (+, -, *, /): ").strip()
                if operation in ['+', '-', '*', '/']:
                    logger.info(f"User selected operation: {operation}")
                    break
                print("❌ Invalid operation. Please choose from: +, -, *, /")
            
            while True:
                try:
                    num2_input = input("Enter second number: ").strip()
                    num2 = float(num2_input)
                    logger.info(f"User entered second number: {num2}")
                    break
                except ValueError:
                    print("❌ Invalid input. Please enter a valid number.")
            
            return {
                'num1': num1,
                'num2': num2,
                'operation': operation
            }
        
        except (KeyboardInterrupt, EOFError):
            print("\n\nOperation cancelled by user.")
            logger.info("User cancelled input")
            sys.exit(0)
    
    def send_request(self, request_data: dict) -> dict:
        try:
            logger.info(f"Connecting to server at {self.host}:{self.port}")
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
                client_socket.connect((self.host, self.port))
                logger.info("Connected to server successfully")
                
                request_json = json.dumps(request_data)
                logger.info(f"Sending request to server: {request_json}")
                client_socket.sendall(request_json.encode('utf-8'))
                
                response_data = client_socket.recv(1024).decode('utf-8')
                logger.info(f"Received response from server: {response_data}")
                
                response = json.loads(response_data)
                return response
        
        except ConnectionRefusedError:
            logger.error(f"Could not connect to server at {self.host}:{self.port}")
            return {
                'status': 'error',
                'message': f'Could not connect to server at {self.host}:{self.port}. Is the server running?'
            }
        except Exception as e:
            logger.error(f"Error communicating with server: {e}")
            return {
                'status': 'error',
                'message': f'Error: {str(e)}'
            }
    
    def display_result(self, response: dict):
        print(f"\n{'='*60}")
        
        if response['status'] == 'success':
            print("✅ Result:")
            print(f"   {response['operation']}")
            print(f"   Answer: {response['result']}")
            logger.info(f"Operation successful: {response['operation']}")
        else:
            print("❌ Error:")
            print(f"   {response['message']}")
            logger.error(f"Operation failed: {response['message']}")
        
        print(f"{'='*60}\n")
    
    def run(self):
        while True:
            try:
                request_data = self.get_user_input()
                
                response = self.send_request(request_data)
                
                self.display_result(response)
                
                continue_input = input("Perform another calculation? (y/n): ").strip().lower()
                if continue_input != 'y':
                    print("\nThank you for using Arithmetic Calculator!")
                    logger.info("Client shutting down - user chose to exit")
                    break
            
            except KeyboardInterrupt:
                print("\n\nClient stopped by user.")
                logger.info("Client interrupted by user")
                break
            except Exception as e:
                logger.error(f"Unexpected error: {e}")
                print(f"\n❌ Unexpected error: {e}")


def main():
    server_host = sys.argv[1] if len(sys.argv) > 1 else SERVER_HOST
    server_port = int(sys.argv[2]) if len(sys.argv) > 2 else SERVER_PORT
    
    client = ArithmeticClient(server_host, server_port)
    client.run()


if __name__ == '__main__':
    main()

