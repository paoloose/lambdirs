import {
  ActionIcon,
  Box,
  Code,
  Group,
  Stack,
  Text,
  TextInput,
  Tooltip,
} from '@mantine/core';
import lambdirsLogo from '/logo_480.png';

import classes from './sidebar.module.css';
import { Search, Plus } from 'lucide-react';
import { UserButton } from '../user-button/user-button';

const collections = [
  { emoji: '👍', label: 'Sales' },
  { emoji: '🚚', label: 'Deliveries' },
  { emoji: '💸', label: 'Discounts' },
  { emoji: '💰', label: 'Profits' },
  { emoji: '✨', label: 'Reports' },
  { emoji: '🛒', label: 'Orders' },
  { emoji: '📅', label: 'Events' },
  { emoji: '🙈', label: 'Debts' },
  { emoji: '💁‍♀️', label: 'Customers' },
];

export function Sidebar() {
  const collectionLinks = collections.map((collection) => (
    <a
      href="#"
      onClick={(e) => e.preventDefault()}
      key={collection.label}
      className={classes.collectionLink}
    >
      <Box component="span" mr={9} fz={16}>
        {collection.emoji}
      </Box>{' '}
      {collection.label}
    </a>
  ));

  return (
    <aside className={classes.navbar}>
      <header className={classes.section}>
        <header className={classes.logoHeader}>
          <a href="/" target="_self" className='flex items-center gap-2'>
            <img className='h-7' src={lambdirsLogo} alt="Lambdirs Logo" />
            <span className='text-xl font-bold'>Lambdirs</span>
          </a>
        </header>
      </header>
      <Stack justify='space-between' h={'100%'}>
        <section>
          <TextInput
            placeholder="Search"
            size="sm"
            leftSection={<Search size={12} strokeWidth={1.5} />}
            rightSectionWidth={80}
            rightSection={<Code className={classes.searchCode}>Ctrl + K</Code>}
            styles={{ section: { pointerEvents: 'none' } }}
            mb="sm"
          />
          <div className={classes.section}>
            <Group className={classes.collectionsHeader} justify="space-between">
              <Text size='sm' fw={500} c="dimmed">
                Collections
              </Text>
              <Tooltip label="Create collection" withArrow position="right">
                <ActionIcon variant="default" size={18}>
                  <Plus size={12} strokeWidth={1.5} />
                </ActionIcon>
              </Tooltip>
            </Group>
            <div className={classes.collections}>{collectionLinks}</div>
          </div>
        </section>
        <section className='py-2'>
          <UserButton />
        </section>
      </Stack>
    </aside>
  );
}
