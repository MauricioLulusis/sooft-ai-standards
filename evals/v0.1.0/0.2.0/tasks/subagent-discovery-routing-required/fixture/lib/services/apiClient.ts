export function request(path: string, token?: string): Promise<unknown> {
  return Promise.resolve({ path, token });
}
