import { Handler } from 'aws-lambda';

export const handler: Handler = async (event, context) => {
    console.log('Started health handler');
    console.log('Event:', JSON.stringify(event));

    return {
        status: 'OK',
        event: event,
        logStreamName: context.logStreamName,
        awsRequestId: context.awsRequestId,
        functionVersion: context.functionVersion,
    };
};
