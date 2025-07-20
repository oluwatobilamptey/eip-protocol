import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.5.4/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
  name: "EIP Protocol: Group Creation Test",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const block = chain.mineBlock([
      Tx.contractCall('eip-protocol-core', 'create-group', 
        [types.ascii('Team Project Expenses')], 
        deployer.address)
    ]);

    // Assert group creation
    assertEquals(block.receipts.length, 1);
    assertEquals(block.receipts[0].result.expectOk(), 1n);  // First group ID
  }
});

Clarinet.test({
  name: "EIP Protocol: Member Addition Test",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const user1 = accounts.get('wallet_1')!;

    const block = chain.mineBlock([
      // First, create a group
      Tx.contractCall('eip-protocol-core', 'create-group', 
        [types.ascii('Team Project Expenses')], 
        deployer.address),
      // Then add a member
      Tx.contractCall('eip-protocol-core', 'add-member', 
        [types.uint(1), types.principal(user1.address)], 
        deployer.address)
    ]);

    // Assert member addition
    assertEquals(block.receipts.length, 2);
    assertEquals(block.receipts[1].result.expectOk(), true);
  }
});

Clarinet.test({
  name: "EIP Protocol: Expense Addition Test",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const user1 = accounts.get('wallet_1')!;

    const block = chain.mineBlock([
      // Create group
      Tx.contractCall('eip-protocol-core', 'create-group', 
        [types.ascii('Team Project Expenses')], 
        deployer.address),
      // Add member
      Tx.contractCall('eip-protocol-core', 'add-member', 
        [types.uint(1), types.principal(user1.address)], 
        deployer.address),
      // Add an expense
      Tx.contractCall('eip-protocol-core', 'add-expense', 
        [
          types.uint(1), 
          types.ascii('Software Licenses'), 
          types.uint(500), 
          types.ascii('equal')
        ], 
        deployer.address)
    ]);

    // Assert expense addition
    assertEquals(block.receipts.length, 3);
    assertEquals(block.receipts[2].result.expectOk(), 1n);  // First expense ID
  }
});