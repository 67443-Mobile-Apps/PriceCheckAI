import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { HomeScreen } from '../screens/HomeScreen';
import { ScanPickerScreen } from '../screens/ScanPickerScreen';
import { ResultsScreen } from '../screens/ResultsScreen';
import { HistoryScreen } from '../screens/HistoryScreen';
import type {
  HistoryStackParamList,
  RootTabParamList,
  ScanStackParamList,
} from './types';
import { colors } from '../theme/theme';

const ScanStack = createNativeStackNavigator<ScanStackParamList>();
const HistoryStack = createNativeStackNavigator<HistoryStackParamList>();
const Tabs = createBottomTabNavigator<RootTabParamList>();

function ScanStackNavigator() {
  return (
    <ScanStack.Navigator>
      <ScanStack.Screen name="Home" component={HomeScreen} options={{ headerShown: false }} />
      <ScanStack.Screen name="ScanPicker" component={ScanPickerScreen} options={{ title: 'Scan an item' }} />
      <ScanStack.Screen name="Results" component={ResultsScreen} options={{ title: 'Price Check Results' }} />
    </ScanStack.Navigator>
  );
}

function HistoryStackNavigator() {
  return (
    <HistoryStack.Navigator>
      <HistoryStack.Screen name="History" component={HistoryScreen} options={{ title: 'Price History' }} />
    </HistoryStack.Navigator>
  );
}

export function AppNavigator() {
  return (
    <Tabs.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.brand,
        tabBarInactiveTintColor: colors.onSurfaceMuted,
      }}
    >
      <Tabs.Screen
        name="Scan"
        component={ScanStackNavigator}
        options={{
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="barcode-outline" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="History"
        component={HistoryStackNavigator}
        options={{
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="time-outline" size={size} color={color} />
          ),
        }}
      />
    </Tabs.Navigator>
  );
}
