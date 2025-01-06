import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let lastTokenId = 0;
const tokenMetadata = new Map();
const tokenOwners = new Map();

// Simulated contract functions
function mintBiosignature(sampleId: number, name: string, description: string, imageUrl: string, confidenceLevel: number, creator: string) {
  const tokenId = ++lastTokenId;
  tokenMetadata.set(tokenId, {
    creator,
    sampleId,
    name,
    description,
    imageUrl,
    discoveryDate: Date.now(),
    confidenceLevel
  });
  tokenOwners.set(tokenId, creator);
  return tokenId;
}

function transferBiosignature(tokenId: number, sender: string, recipient: string) {
  if (tokenOwners.get(tokenId) !== sender) throw new Error('Not authorized');
  tokenOwners.set(tokenId, recipient);
  return true;
}

describe('Biosignature NFT Contract', () => {
  beforeEach(() => {
    lastTokenId = 0;
    tokenMetadata.clear();
    tokenOwners.clear();
  });
  
  it('should mint a new biosignature NFT', () => {
    const id = mintBiosignature(1, 'Martian Microfossil', 'Potential microfossil found in Martian meteorite', 'https://example.com/martian-fossil.jpg', 75, 'scientist1');
    expect(id).toBe(1);
    const metadata = tokenMetadata.get(id);
    expect(metadata.name).toBe('Martian Microfossil');
    expect(metadata.confidenceLevel).toBe(75);
    expect(tokenOwners.get(id)).toBe('scientist1');
  });
  
  it('should transfer biosignature NFT ownership', () => {
    const id = mintBiosignature(2, 'Europan Amino Acids', 'Complex amino acids detected in Europa\'s ocean', 'https://example.com/europa-amino.jpg', 90, 'scientist2');
    expect(transferBiosignature(id, 'scientist2', 'researcher1')).toBe(true);
    expect(tokenOwners.get(id)).toBe('researcher1');
  });
  
  it('should not allow unauthorized transfers', () => {
    const id = mintBiosignature(3, 'Titan Membrane Structures', 'Potential cell membrane analogues in Titan\'s hydrocarbon lakes', 'https://example.com/titan-membranes.jpg', 60, 'scientist3');
    expect(() => transferBiosignature(id, 'unauthorized_user', 'researcher2')).toThrow('Not authorized');
  });
});

