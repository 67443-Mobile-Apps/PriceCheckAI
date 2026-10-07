import React, { createContext, useContext, useMemo, type ReactNode } from 'react';
import { createHistoryStore, type HistoryStore } from '../db/historyStore';
import { openDatabase } from '../db/client';

const HistoryStoreContext = createContext<HistoryStore | null>(null);

export function HistoryStoreProvider({ children }: { children: ReactNode }) {
  const store = useMemo(() => createHistoryStore(openDatabase()), []);
  return <HistoryStoreContext.Provider value={store}>{children}</HistoryStoreContext.Provider>;
}

export function useHistoryStore(): HistoryStore {
  const store = useContext(HistoryStoreContext);
  if (!store) throw new Error('useHistoryStore must be used inside a HistoryStoreProvider');
  return store;
}
