import type { APIItem, BarcodeEntry, PriceLookup } from './types';

export interface PriceAPI {
  lookup(barcode: string, location: string): Promise<PriceLookup | null>;
  allBarcodes(): Promise<BarcodeEntry[]>;
  knownLocations(): Promise<string[]>;
}

export function makeMockPriceAPI(dataSource: () => APIItem[]): PriceAPI {
  let cache: APIItem[] | null = null;
  const load = (): APIItem[] => (cache ??= dataSource());

  return {
    async lookup(barcode, location) {
      const items = load();
      const item = items.find((i) => i.barcode === barcode);
      if (!item) return null;
      const price = item.prices.find((p) => p.location === location);
      if (!price) return null;
      return {
        barcode: item.barcode,
        itemName: item.item,
        price: price.price,
        location: price.location,
        date: dateDaysAgo(price.daysAgo),
      };
    },

    async allBarcodes() {
      const items = load();
      return items
        .map((i): BarcodeEntry => ({ barcode: i.barcode, item: i.item }))
        .sort((a, b) => a.item.localeCompare(b.item, undefined, { sensitivity: 'base' }));
    },

    async knownLocations() {
      const items = load();
      const all = items.flatMap((i) => i.prices.map((p) => p.location));
      return Array.from(new Set(all)).sort();
    },
  };
}

export function bundledMockPriceAPI(): PriceAPI {
  return makeMockPriceAPI(() => require('../../assets/prices.json') as APIItem[]);
}

function dateDaysAgo(daysAgo: number): Date {
  return new Date(Date.now() - daysAgo * 24 * 60 * 60 * 1000);
}
