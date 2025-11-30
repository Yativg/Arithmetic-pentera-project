import socket
import json
import logging
from operations import OperationFactory

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

HOST = '0.0.0.0'
PORT = 5555


class ArithmeticServer:
    
    def __init__(self, host: str, port: int):
        self.host = host
        self.port = port
        self.socket = None
        logger.info(f"Initializing Arithmetic Server on {host}:{port}")
    
    def start(self):
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            
            self.socket.bind((self.host, self.port))
            
            self.socket.listen(5)
            
            logger.info(f"Server started successfully and listening on {self.host}:{self.port}")
            logger.info(f"Supported operations: {', '.join(OperationFactory.get_supported_operations())}")
            print(f"\n{'='*60}")
            print(f"🚀 Arithmetic Server is RUNNING!")
            print(f"{'='*60}")
            print(f"Listening on: {self.host}:{self.port}")
            print(f"Supported operations: {', '.join(OperationFactory.get_supported_operations())}")
            print(f"{'='*60}\n")
            
            while True:
                try:
                    conn, addr = self.socket.accept()
                    logger.info(f"New connection from {addr}")
                    self.handle_client(conn, addr)
                except Exception as e:
                    logger.error(f"Error handling client connection: {e}")
        
        except Exception as e:
            logger.error(f"Failed to start server: {e}")
            raise
        finally:
            self.stop()
    
    def handle_client(self, conn: socket.socket, addr: tuple):
        try:
            data = conn.recv(1024).decode('utf-8')
            
            if not data:
                logger.warning(f"Received empty data from {addr}")
                return
            
            logger.info(f"Received data from {addr}: {data}")
            
            try:
                request = json.loads(data)
                num1 = float(request['num1'])
                num2 = float(request['num2'])
                operation_symbol = request['operation']
                
                logger.info(f"Parsed request - Operation: {operation_symbol}, Num1: {num1}, Num2: {num2}")
                
                operation = OperationFactory.get_operation(operation_symbol)
                result = operation.execute(num1, num2)
                
                response = {
                    'status': 'success',
                    'result': result,
                    'operation': f"{num1} {operation_symbol} {num2} = {result}"
                }
                
                logger.info(f"Calculation successful: {response['operation']}")
                
            except (KeyError, ValueError, json.JSONDecodeError) as e:
                logger.error(f"Invalid request format or values: {e}")
                response = {
                    'status': 'error',
                    'message': str(e)
                }
            
            response_json = json.dumps(response)
            conn.sendall(response_json.encode('utf-8'))
            logger.info(f"Sent response to {addr}: {response_json}")
            
        except Exception as e:
            logger.error(f"Error processing request from {addr}: {e}")
            error_response = json.dumps({'status': 'error', 'message': 'Internal server error'})
            try:
                conn.sendall(error_response.encode('utf-8'))
            except:
                pass
        finally:
            conn.close()
            logger.info(f"Connection closed with {addr}")
    
    def stop(self):
        if self.socket:
            logger.info("Shutting down server...")
            self.socket.close()
            logger.info("Server stopped")


def main():
    server = ArithmeticServer(HOST, PORT)
    try:
        server.start()
    except KeyboardInterrupt:
        logger.info("Server interrupted by user")
        print("\n\nServer stopped by user")
    except Exception as e:
        logger.error(f"Server error: {e}")
        print(f"\nServer error: {e}")


if __name__ == '__main__':
    main()

