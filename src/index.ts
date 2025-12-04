import { registerPlugin } from '@capacitor/core';

import type { AppVersionManagerPlugin } from './definitions';

const AppVersionManager = registerPlugin<AppVersionManagerPlugin>('AppVersionManager', {
  web: () => import('./web').then((m) => new m.AppVersionManagerWeb()),
});

export * from './definitions';
export { AppVersionManager };
