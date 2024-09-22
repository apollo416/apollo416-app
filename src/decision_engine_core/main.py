import random
import logging

from aws_lambda_powertools import Logger
from aws_lambda_powertools import Tracer
from aws_lambda_powertools.utilities.typing import LambdaContext

from codeguru_profiler_agent import with_lambda_profiler

logger = Logger()
tracer = Tracer()

@with_lambda_profiler()
@logger.inject_lambda_context(log_event=True)
@tracer.capture_lambda_handler
def handler(event, context):
    print("Hello from main handler")
    num = random.randrange(100)
    logger.info(f"Random number: {num}", extra={"num": num})
    count = 0
    for _ in range(num):
        x = random.randrange(num)
        if check_prime(x):
            count += 1
    return count

@tracer.capture_method
def check_prime(num):
    if num == 1 or num == 0:
        return False
    sq_root = 2
    while sq_root * sq_root <= num:
        if num % sq_root == 0:
            return False
        sq_root += 1
    return True