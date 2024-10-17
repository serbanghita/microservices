import { DbService } from './db.service';
import { Injectable } from '@nestjs/common';
import { Token, TokenType } from '@prisma/client';

@Injectable()
export class TokeService {
  constructor(private prisma: DbService) {}

  async login(
    username: string,
    password: string,
    scope: string,
  ): Promise<Token> {
    const client = await this.prisma.apiClient.findFirst({
      where: { username, password },
    });

    const requestedScopes = scope.split(',');

    const clientScopesAndClaims =
      await this.prisma.apiClientAssignedScopes.findMany({
        where: {
          clientId: client.id,
          scope: { name: { in: requestedScopes } },
        },
        include: { claim: true },
      });

    return this.prisma.token.create({
      data: {
        type: TokenType.ACCESS_TOKEN,
        jwtId: 'abc',
        clientId: client.id,
        content: 'jwt string here',
        createdAt: new Date().toISOString(),
      },
    });
  }
}
