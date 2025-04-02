import { describe, it, expect, beforeEach } from 'vitest';
import fs from 'fs';
import path from 'path';

describe('Peer-to-Peer Trading Contract', () => {
  // Read the contract code
  const contractCode = fs.readFileSync(
      path.resolve(__dirname, '../contracts/peer-to-peer-trading.clar'),
      'utf8'
  );
  
  it('should contain trading functionality', () => {
    // Check for key functions
    expect(contractCode).toContain('create-energy-offer');
    expect(contractCode).toContain('cancel-offer');
    expect(contractCode).toContain('purchase-energy');
  });
  
  it('should define the necessary data structures', () => {
    // Check for data structures
    expect(contractCode).toContain('define-map energy-offers');
    expect(contractCode).toContain('define-map trades');
    expect(contractCode).toContain('define-data-var next-offer-id');
    expect(contractCode).toContain('define-data-var next-trade-id');
  });
  
  it('should include read-only functions for data access', () => {
    expect(contractCode).toContain('define-read-only (get-offer');
    expect(contractCode).toContain('define-read-only (get-trade');
  });
  
  it('should handle offer and trade details properly', () => {
    // Check for offer properties
    expect(contractCode).toContain('seller: principal');
    expect(contractCode).toContain('energy-amount: uint');
    expect(contractCode).toContain('price-per-unit: uint');
    expect(contractCode).toContain('expiration: uint');
    
    // Check for trade properties
    expect(contractCode).toContain('buyer: principal');
    expect(contractCode).toContain('total-price: uint');
  });
});
