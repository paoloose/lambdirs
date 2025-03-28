import { Box, LoadingOverlay } from '@mantine/core';
import bg from '/background.png';

export function LoadingFullscreenOverlay() {
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
      <LoadingOverlay visible={true} />
    </Box >
  );
}
