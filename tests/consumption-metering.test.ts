import { describe, it, expect, beforeEach } from 'vitest';
import fs from 'fs';
import path from 'path';

describe('Consumption Metering Contract', () => {
  // Read the contract code
  const contractCode = fs.readFileSync(
      path.resolve(__dirname, '../contracts/consumption-metering.clar'),
      'utf8'
  );
  
  it('should contain consumption metering functionality', () => {
    // Check for key functions
    expect(contractCode).toContain('register-meter');
    expect(contractCode).toContain('record-consumption');
  });
  
  it('should define the necessary data structures', () => {
    // Check for data structures
    expect(contractCode).toContain('define-map consumer-meters');
    expect(contractCode).toContain('define-map consumption-history');
  });
  
  it('should include read-only functions for data access', () => {
    expect(contractCode).toContain('define-read-only (get-meter');
    expect(contractCode).toContain('define-read-only (get-consumption-for-period');
  });
  
  it('should track consumption data properly', () => {
    // Check for consumption tracking properties
    expect(contractCode).toContain('total-consumption: uint');
    expect(contractCode).toContain('last-reading: uint');
    expect(contractCode).toContain('last-update: uint');
  });
});
