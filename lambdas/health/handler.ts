import { Handler, APIGatewayProxyResult } from 'aws-lambda';

export const handler: Handler<any, APIGatewayProxyResult> = async (event, context) => {
    console.log('Started health handler');
    console.log('Event:', JSON.stringify(event));

    return {
        statusCode: 200,
        body: JSON.stringify({
            status: 'OK',
            event: event,
            logStreamName: context.logStreamName,
            awsRequestId: context.awsRequestId,
            functionVersion: context.functionVersion,
        }),
    };
};
