interface Credentials {
  username: string;
  password: string;
}

export class AuthService {
  constructor(private readonly userStore: UserStore) {}

  async login({ username, password }: Credentials): Promise<Session> {
    const user = await this.userStore.findByUsername(username);
    if (!user || !user.verifyPassword(password)) {
      throw new Error("Credenciales inválidas");
    }
    return this.userStore.createSession(user);
  }
}

interface UserStore {
  findByUsername(username: string): Promise<User | null>;
  createSession(user: User): Promise<Session>;
}

interface User {
  verifyPassword(password: string): boolean;
}

interface Session {
  token: string;
  expiresAt: Date;
}
