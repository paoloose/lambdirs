import { Avatar, Group, Menu, Text, UnstyledButton } from '@mantine/core';
import { LogOut } from 'lucide-react';
import avatar from '@/assets/user-avatar.webp';
import { useUser } from '@/stores/user-store';
import classes from './user-button.module.css';

export function UserButton() {
  const user = useUser();

  if (!user.data || user.data === 'loading' || user.data === 'error') {
    return null;
  }

  return (
    <Menu width={200}>
      <Menu.Target>
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
      </Menu.Target>
      <Menu.Dropdown>
        <Menu.Label>Account</Menu.Label>
        <Menu.Item
          leftSection={<LogOut size={13} />}
          onClick={() => {
            useUser.getState().logout();
          }}
        >
          <Text size="sm">Logout</Text>
        </Menu.Item>
      </Menu.Dropdown>
    </Menu>
  );
}
