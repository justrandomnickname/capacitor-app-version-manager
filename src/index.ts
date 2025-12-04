import { registerPlugin } from '@capacitor/core';

import type { AppVersionManagerPlugin } from './definitions';

const AppVersionManager = registerPlugin<AppVersionManagerPlugin>('AppVersionManager');

export * from './definitions';
export { AppVersionManager };
