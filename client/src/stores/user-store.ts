import { ACCESS_TOKEN_KEY } from '@/utils/auth';
import { OAUTH_SERVER_URL } from '@/utils/env';
import { create } from 'zustand';

export type UserData = {
    sub: string;
    email: string;
    email_verified: boolean;
    name: string;
};

interface UserStore {
    data: UserData | 'loading' | 'error';
    fetch: () => Promise<void>;
}

export const useUser = create<UserStore>()((set) => ({
    data: 'loading',
    async fetch() {
        const accessToken = window.localStorage.getItem(ACCESS_TOKEN_KEY);
        if (!accessToken) {
            set({
                data: 'error'
            });
            return;
        }

        const response = await window.fetch(`${OAUTH_SERVER_URL}/oauth2/userInfo`, {
            headers: {
                'Content-Type': 'application/x-amz-json-1.1',
                'Authorization': `Bearer ${accessToken}`,
                'Accept': '*/*',
                'Accept-Encoding': 'gzip, deflate, br',
                'Connection': 'keep-alive',
            },
        });
        const userInfo = await response.json();
        if (!userInfo.sub || !userInfo.email || !userInfo.name) {
            set({
                data: 'error',
            });
            return;
        }
        set({
            data: {
                sub: userInfo.sub,
                email: userInfo.email,
                email_verified: userInfo.email_verified,
                name: userInfo.name,
            },
        });
    },
}));
