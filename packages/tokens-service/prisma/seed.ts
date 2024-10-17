import { ClaimType, PrismaClient, TokenType } from '@prisma/client';
import { faker } from '@faker-js/faker';

const prisma = new PrismaClient();
async function main() {
  const apiClient = await prisma.apiClient.create({
    data: {
      organisationId: faker.number.int({ max: 99999 }),
      username: faker.string.alphanumeric({ length: 20, casing: 'lower' }),
      password: faker.string.alphanumeric({ length: 64 }),
      isActive: true,
      createdAt: new Date().toISOString(),
    },
  });

  const scope_stations = await prisma.scope.create({
    data: {
      name: 'stations',
      description: 'Access to Stations',
      isActive: true,
    },
  });

  const claim1 = await prisma.claim.create({
    data: {
      key: 'read',
      value: '12345',
      type: ClaimType.INTEGER,
    },
  });

  const claim2 = await prisma.claim.create({
    data: {
      key: 'read',
      value: '67890',
      type: ClaimType.INTEGER,
    },
  });

  const grant = await prisma.grant.create({
    data: {
      claims: faker.string.alphanumeric(),
      createdAt: new Date().toISOString(),
      expiresAt: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(),
      apiClient: {
        connect: {
          id: apiClient.id,
        },
      },
    },
  });

  await prisma.apiClientAssignedScopes.create({
    data: {
      clientId: apiClient.id,
      scopeId: scope_stations.id,
      claimId: claim1.id,
    },
  });

  await prisma.apiClientAssignedScopes.create({
    data: {
      clientId: apiClient.id,
      scopeId: scope_stations.id,
      claimId: claim2.id,
    },
  });

  for (let j = 0; j <= 100; j++) {
    await prisma.token.create({
      data: {
        type: TokenType.ACCESS_TOKEN,
        jwtId: faker.string.uuid(),
        content: faker.string.alphanumeric({ length: 200 }),
        createdAt: new Date().toISOString(),
        isRevoked: false,
        revokedAt: null,
        client: {
          connect: {
            id: apiClient.id,
          },
        },
        grant: {
          connect: { id: grant.id },
        },
      },
    });
  }

  console.log({ apiClient });
}
main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
