import React, { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { NavigationContainer } from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { bundledMockPriceAPI } from './src/api/priceAPI';
import { AppNavigator } from './src/navigation/AppNavigator';
import { PriceAPIProvider } from './src/stores/PriceAPIContext';
import { HistoryStoreProvider, useHistoryStore } from './src/stores/HistoryStoreContext';
import { LocationStoreProvider } from './src/stores/LocationStore';

const api = bundledMockPriceAPI();

export default function App() {
  return (
    <SafeAreaProvider>
      <PriceAPIProvider api={api}>
        <HistoryStoreProvider>
          <LocationStoreProvider api={api}>
            <NavigationContainer>
              <AppStartup />
              <AppNavigator />
              <StatusBar style="auto" />
            </NavigationContainer>
          </LocationStoreProvider>
        </HistoryStoreProvider>
      </PriceAPIProvider>
    </SafeAreaProvider>
  );
}

function AppStartup() {
  const store = useHistoryStore();
  useEffect(() => {
    store.purgeOlderThan(90);
  }, [store]);
  return null;
}
