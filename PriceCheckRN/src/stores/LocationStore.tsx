import React, {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import type { PriceAPI } from '../api/priceAPI';

type LocationStoreValue = {
  all: string[];
  current: string;
  setCurrent: (chain: string) => void;
};

const STORAGE_KEY = 'PriceCheck.LocationStore.current';

const LocationStoreContext = createContext<LocationStoreValue | null>(null);

export type Storage = Pick<typeof AsyncStorage, 'getItem' | 'setItem'>;

type ProviderProps = {
  api: PriceAPI;
  storage?: Storage;
  children: ReactNode;
};

export function LocationStoreProvider({
  api,
  storage = AsyncStorage,
  children,
}: ProviderProps) {
  const [all, setAll] = useState<string[]>([]);
  const [current, setCurrentState] = useState<string>('');
  const [hydrated, setHydrated] = useState(false);

  // Hydrate the stored current value once.
  useEffect(() => {
    let cancelled = false;
    storage.getItem(STORAGE_KEY).then((stored) => {
      if (cancelled) return;
      if (stored) setCurrentState(stored);
      setHydrated(true);
    });
    return () => {
      cancelled = true;
    };
  }, [storage]);

  // Load locations from the API once.
  useEffect(() => {
    let cancelled = false;
    api.knownLocations().then((locations) => {
      if (cancelled) return;
      setAll(locations);
    });
    return () => {
      cancelled = true;
    };
  }, [api]);

  // Reconcile current against the loaded set.
  useEffect(() => {
    if (!hydrated || all.length === 0) return;
    if (current === '' || !all.includes(current)) {
      setCurrentState(all[0]);
    }
  }, [hydrated, all, current]);

  const setCurrent = (chain: string) => {
    setCurrentState(chain);
    void storage.setItem(STORAGE_KEY, chain);
  };

  const value = useMemo<LocationStoreValue>(
    () => ({ all, current, setCurrent }),
    [all, current],
  );

  return (
    <LocationStoreContext.Provider value={value}>
      {children}
    </LocationStoreContext.Provider>
  );
}

export function useLocationStore(): LocationStoreValue {
  const ctx = useContext(LocationStoreContext);
  if (!ctx) {
    throw new Error('useLocationStore must be used inside a LocationStoreProvider');
  }
  return ctx;
}
