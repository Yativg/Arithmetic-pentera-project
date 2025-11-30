from abc import ABC, abstractmethod
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


class Operation(ABC):
    
    @abstractmethod
    def execute(self, a: float, b: float) -> float:
        pass
    
    @abstractmethod
    def get_symbol(self) -> str:
        pass


class AddOperation(Operation):
    
    def execute(self, a: float, b: float) -> float:
        result = a + b
        logger.info(f"Executing addition: {a} + {b} = {result}")
        return result
    
    def get_symbol(self) -> str:
        return "+"


class SubtractOperation(Operation):
    
    def execute(self, a: float, b: float) -> float:
        result = a - b
        logger.info(f"Executing subtraction: {a} - {b} = {result}")
        return result
    
    def get_symbol(self) -> str:
        return "-"


class MultiplyOperation(Operation):
    
    def execute(self, a: float, b: float) -> float:
        result = a * b
        logger.info(f"Executing multiplication: {a} * {b} = {result}")
        return result
    
    def get_symbol(self) -> str:
        return "*"


class DivideOperation(Operation):
    
    def execute(self, a: float, b: float) -> float:
        if b == 0:
            logger.error("Attempted division by zero")
            raise ValueError("Cannot divide by zero")
        result = a / b
        logger.info(f"Executing division: {a} / {b} = {result}")
        return result
    
    def get_symbol(self) -> str:
        return "/"


class OperationFactory:
    
    _operations = {
        '+': AddOperation,
        '-': SubtractOperation,
        '*': MultiplyOperation,
        '/': DivideOperation,
    }
    
    @classmethod
    def get_operation(cls, symbol: str) -> Operation:
        operation_class = cls._operations.get(symbol)
        if operation_class is None:
            logger.error(f"Invalid operation symbol: {symbol}")
            raise ValueError(f"Invalid operation: {symbol}. Supported operations: {', '.join(cls._operations.keys())}")
        
        logger.debug(f"Created operation instance for symbol: {symbol}")
        return operation_class()
    
    @classmethod
    def get_supported_operations(cls) -> list:
        return list(cls._operations.keys())

