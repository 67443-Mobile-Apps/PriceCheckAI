import React from 'react';
import { Text, Pressable } from 'react-native';
import { render, screen, waitFor, fireEvent } from '@testing-library/react-native';
import {
  LocationStoreProvider,
  useLocationStore,
  type Storage,
} from '../../src/stores/LocationStore';
import { makeMockPriceAPI } from '../../src/api/priceAPI';
import type { APIItem } from '../../src/api/types';

const sample: APIItem[] = [
  { barcode: 'A', item: 'Alpha', prices: [{ location: 'Target', price: 1, daysAgo: 1 }] },
  { barcode: 'B', item: 'Beta', prices: [{ location: 'Giant Eagle', price: 2, daysAgo: 2 }] },
  { barcode: 'C', item: 'Gamma', prices: [{ location: 'Aldi', price: 3, daysAgo: 3 }] },
];

function memoryStorage(initial: Record<string, string> = {}): {
  storage: Storage;
  getItem: (k: string) => string | undefined;
} {
  const store: Record<string, string> = { ...initial };
  return {
    storage: {
      getItem: (k) => Promise.resolve(store[k] ?? null),
      setItem: (k, v) => {
        store[k] = v;
        return Promise.resolve();
      },
    },
    getItem: (k) => store[k],
  };
}

function Probe({ pressTarget }: { pressTarget?: string }) {
  const { all, current, setCurrent } = useLocationStore();
  return (
    <>
      <Text testID="all">{all.join(',')}</Text>
      <Text testID="current">{current}</Text>
      {pressTarget !== undefined ? (
        <Pressable testID="btn" onPress={() => setCurrent(pressTarget)}>
          <Text>press</Text>
        </Pressable>
      ) : null}
    </>
  );
}

describe('LocationStoreProvider', () => {
  it('populates `all` sorted alphabetically after load', async () => {
    const { storage } = memoryStorage();
    render(
      <LocationStoreProvider api={makeMockPriceAPI(() => sample)} storage={storage}>
        <Probe />
      </LocationStoreProvider>,
    );

    await waitFor(() => {
      expect(screen.getByTestId('all').props.children).toBe('Aldi,Giant Eagle,Target');
    });
  });

  it('defaults current to first alphabetical on first mount', async () => {
    const { storage } = memoryStorage();
    render(
      <LocationStoreProvider api={makeMockPriceAPI(() => sample)} storage={storage}>
        <Probe />
      </LocationStoreProvider>,
    );

    await waitFor(() => {
      expect(screen.getByTestId('current').props.children).toBe('Aldi');
    });
  });

  it('setCurrent updates state and writes to storage', async () => {
    const mem = memoryStorage();

    render(
      <LocationStoreProvider api={makeMockPriceAPI(() => sample)} storage={mem.storage}>
        <Probe pressTarget="Target" />
      </LocationStoreProvider>,
    );
    await waitFor(() => expect(screen.getByTestId('current').props.children).toBe('Aldi'));

    fireEvent.press(screen.getByTestId('btn'));

    await waitFor(() => expect(screen.getByTestId('current').props.children).toBe('Target'));
    expect(mem.getItem('PriceCheck.LocationStore.current')).toBe('Target');
  });

  it('hydrates current from storage when the stored chain is still valid', async () => {
    const { storage } = memoryStorage({ 'PriceCheck.LocationStore.current': 'Target' });
    render(
      <LocationStoreProvider api={makeMockPriceAPI(() => sample)} storage={storage}>
        <Probe />
      </LocationStoreProvider>,
    );
    await waitFor(() => expect(screen.getByTestId('current').props.children).toBe('Target'));
  });

  it('resets current when stored chain is no longer in the loaded set', async () => {
    const { storage } = memoryStorage({ 'PriceCheck.LocationStore.current': 'Whole Foods' });
    render(
      <LocationStoreProvider api={makeMockPriceAPI(() => sample)} storage={storage}>
        <Probe />
      </LocationStoreProvider>,
    );
    await waitFor(() => expect(screen.getByTestId('current').props.children).toBe('Aldi'));
  });
});
