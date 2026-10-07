export type APIPrice = {
  location: string;
  price: number;
  daysAgo: number;
};

export type APIItem = {
  barcode: string;
  item: string;
  prices: APIPrice[];
};

export type BarcodeEntry = {
  barcode: string;
  item: string;
};

export type PriceLookup = {
  barcode: string;
  itemName: string;
  price: number;
  location: string;
  date: Date;
};
