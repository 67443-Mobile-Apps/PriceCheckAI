import { TextStyle } from 'react-native';

export const colors = {
  brand: '#4F46E5',
  brandMuted: '#C7D2FE',
  accent: '#14B8A6',

  surface: '#F5F5F7',
  surfaceElevated: '#FFFFFF',

  onSurface: '#0B0B0F',
  onSurfaceMuted: '#6B7280',

  danger: '#DC2626',
  success: '#16A34A',
  divider: '#E5E7EB',

  white: '#FFFFFF',
} as const;

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
} as const;

export const radius = {
  small: 8,
  medium: 14,
  large: 20,
  pill: 999,
} as const;

export const text = {
  titleXL: {
    fontSize: 34,
    fontWeight: '700' as const,
    letterSpacing: -0.5,
  } satisfies TextStyle,
  title: {
    fontSize: 22,
    fontWeight: '600' as const,
    letterSpacing: -0.2,
  } satisfies TextStyle,
  body: {
    fontSize: 17,
    fontWeight: '400' as const,
  } satisfies TextStyle,
  caption: {
    fontSize: 13,
    fontWeight: '400' as const,
  } satisfies TextStyle,
  mono: {
    fontSize: 13,
    fontFamily: 'Menlo',
  } satisfies TextStyle,
} as const;

export const brandGradientColors: [string, string] = [colors.brand, colors.accent];

export const shadow = {
  card: {
    shadowColor: '#000',
    shadowOpacity: 0.06,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 4 },
    elevation: 2,
  },
  button: {
    shadowColor: colors.brand,
    shadowOpacity: 0.35,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 8 },
    elevation: 4,
  },
} as const;
