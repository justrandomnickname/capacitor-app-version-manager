export interface AppVersionManagerPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
