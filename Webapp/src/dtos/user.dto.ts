import { Prisma, PrismaClient, User } from "@prisma/client";

export class UserDto {
    id: string;
    username: string;
    password: string;
    first_name: string;
    last_name: string;
    account_created: Date | null;
    account_updated: Date | null;
    constructor(id: string, username: string, password: string, first_name: string, last_name: string, account_created: Date | null = null, account_updated: Date | null = null) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.first_name = first_name;
        this.last_name = last_name;        
        this.account_created = account_created;
        this.account_updated = account_updated;
    }
    fromPrisma(user: User) {
        return new UserDto(user.id, user.username, user.password, user.firstName, user.lastName, user.accountCreated, user.accountUpdated);
    }
    toPrisma() {
        return {
            id: this.id,
            username: this.username,
            password: this.password,
            firstName: this.first_name,
            lastName: this.last_name,
            accountCreated: this.account_created,
            accountUpdated: this.account_updated
        } as User;
    }
    toResponse() {
        return { id: this.id, username: this.username, first_name: this.first_name, last_name: this.last_name, account_created: this.account_created, account_updated: this.account_updated}
    }
}