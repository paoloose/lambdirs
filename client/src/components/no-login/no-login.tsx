import { Anchor, Box, Button, Group, Image, LoadingOverlay, Paper, Stack, Text, Title } from "@mantine/core";
import { OAUTH_CLIENT_ID, OAUTH_REDIRECT_URI, OAUTH_SERVER_URL } from "@/utils/env";
import github from '@/assets/icons/github.png';
import { useDisclosure } from "@mantine/hooks";
import { openOAuthUrl } from "@/utils/auth";
import lambdirsLogo from '/logo_480.png';
import bg from '/background.png';

export function NoLogin() {
  const [redirecting, { open: showLoadingOverlay }] = useDisclosure(false);

  const onLogin = () => {
    showLoadingOverlay();
    openOAuthUrl({
      url: OAUTH_SERVER_URL,
      clientId: OAUTH_CLIENT_ID,
      redirectUri: OAUTH_REDIRECT_URI,
    });
    // NOTE: The redirect uri MUST BE A ROUTE OF MY API GATEWAY
    //       And that endpoint should redirect me back to my frontend
  }

  return (
    <Box
      w={'100vw'}
      h={'100vh'}
      mx='auto'
      display={'flex'}
      className={`bg-cover items-center justify-center`}
      style={{
        backgroundImage: `url(${bg})`,
      }}
    >
      <Paper bg={'var(--mantine-color-body)'} withBorder p={'xl'} radius={'md'}>
        <LoadingOverlay visible={redirecting} />
        <Stack>
          <Group>
            <Image w={50} src={lambdirsLogo} alt='Lambdirs Logo' />
            <Title order={1} size='h1'>Lambdirs</Title>
          </Group>
          <Text size='lg'>
            Fully serverless cloud storage AWS solution deployed w/ OpenTofu
          </Text>
          <Group gap={'xs'}>
            <Image w={25} src={github} alt='GitHub logo' />
            <Anchor size='lg' href='https://github.com/paoloose/lambdirs' target='_blank'>
              Source code on GitHub
            </Anchor>
          </Group>
          <Button c={'black'} size={'md'} radius={'md'} onClick={onLogin}>
            Login
          </Button>
        </Stack>
      </Paper>
    </Box >
  );
}
