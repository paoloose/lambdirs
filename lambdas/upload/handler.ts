import { Handler, APIGatewayProxyResult, APIGatewayProxyEvent, APIGatewayProxyWithCognitoAuthorizerEvent } from 'aws-lambda';
import { PutObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { join } from 'node:path';
import { z } from 'zod';

const s3Client = new S3Client();

const payloadParse = z.object({
    key: z.string(),
});

export const handler: Handler<APIGatewayProxyWithCognitoAuthorizerEvent, APIGatewayProxyResult> = async (event, context) => {
    console.log('Event:', JSON.stringify(event));

    if (event.isBase64Encoded || !event.body) {
        return get400Response();
    }

    const payload = payloadParse.safeParse(JSON.parse(event.body));

    if (!payload.success) {
        return get400Response();
    }

    const putCommand = new PutObjectCommand({
        Bucket: 'paoloose-lambdirs-internal',
        Key: join('uploads', payload.data.key),
    });

    const signedUrl = await getSignedUrl(s3Client, putCommand, {
        expiresIn: 6900,
    });

    return {
        statusCode: 200,
        body: JSON.stringify({
            url: signedUrl,
        }),
    };
};

const get400Response = () => {
    return {
        statusCode: 400,
        body: JSON.stringify({
            status: 'ERROR',
            message: 'Invalid request payload',
        }),
    };
}
