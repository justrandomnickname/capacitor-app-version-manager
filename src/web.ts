import { WebPlugin } from '@capacitor/core';

import type { AppVersionManagerPlugin } from './definitions';

export class AppVersionManagerWeb extends WebPlugin implements AppVersionManagerPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
