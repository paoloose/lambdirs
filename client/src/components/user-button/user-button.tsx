import avatar from '@/assets/user-avatar.webp';
import { Avatar, Group, Text, UnstyledButton } from '@mantine/core';
import classes from './user-button.module.css';
import { useUser } from '@/stores/user-store';

export function UserButton() {
  const user = useUser();

  if (user.data === 'loading' || user.data === 'error') {
    return null;
  }

  return (
    <UnstyledButton className={classes.user}>
      <Group>
        <Avatar
          src={avatar}
          radius="xl"
        />

        <div style={{ flex: 1 }}>
          <Text size="sm" fw={500}>
            {user.data.name}
          </Text>

          <Text c="dimmed" size="xs">
            {user.data.email}
          </Text>
        </div>

        {/* <IconChevronRight size={14} stroke={1.5} /> */}
      </Group>
    </UnstyledButton>
  );
}
