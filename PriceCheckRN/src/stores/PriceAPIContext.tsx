import React, { createContext, useContext, type ReactNode } from 'react';
import type { PriceAPI } from '../api/priceAPI';

const PriceAPIContext = createContext<PriceAPI | null>(null);

export function PriceAPIProvider({ api, children }: { api: PriceAPI; children: ReactNode }) {
  return <PriceAPIContext.Provider value={api}>{children}</PriceAPIContext.Provider>;
}

export function usePriceAPI(): PriceAPI {
  const api = useContext(PriceAPIContext);
  if (!api) throw new Error('usePriceAPI must be used inside a PriceAPIProvider');
  return api;
}
