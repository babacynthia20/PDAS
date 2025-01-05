import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let listingCount = 0;
const listings = new Map();
const balances = new Map();

// Simulated contract functions
function createListing(equipmentType: string, description: string, price: number, availability: number, location: string, seller: string) {
  const listingId = ++listingCount;
  listings.set(listingId, {
    seller,
    equipmentType,
    description,
    price,
    availability,
    location
  });
  return listingId;
}

function purchaseAnalysisTime(listingId: number, duration: number, buyer: string) {
  const listing = listings.get(listingId);
  if (!listing) throw new Error('Invalid listing');
  const totalCost = listing.price * duration;
  const buyerBalance = balances.get(buyer) || 0;
  if (buyerBalance < totalCost) throw new Error('Insufficient balance');
  if (listing.availability < duration) throw new Error('Invalid listing');
  balances.set(buyer, buyerBalance - totalCost);
  const sellerBalance = balances.get(listing.seller) || 0;
  balances.set(listing.seller, sellerBalance + totalCost);
  listing.availability -= duration;
  listings.set(listingId, listing);
  return true;
}

function removeListing(listingId: number, remover: string) {
  const listing = listings.get(listingId);
  if (!listing) throw new Error('Invalid listing');
  if (listing.seller !== remover) throw new Error('Not authorized');
  listings.delete(listingId);
  return true;
}

describe('Analysis Marketplace Contract', () => {
  beforeEach(() => {
    listingCount = 0;
    listings.clear();
    balances.clear();
  });
  
  it('should create a new listing', () => {
    const id = createListing('Mass Spectrometer', 'High-resolution mass spectrometer for organic compound analysis', 100, 1000, 'Astrobiology Lab, USA', 'seller1');
    expect(id).toBe(1);
    const listing = listings.get(id);
    expect(listing.equipmentType).toBe('Mass Spectrometer');
    expect(listing.price).toBe(100);
    expect(listing.availability).toBe(1000);
  });
  
  it('should allow purchasing analysis time', () => {
    const id = createListing('DNA Sequencer', 'Next-gen DNA sequencer for potential extraterrestrial genetic material', 200, 500, 'Exobiology Center, EU', 'seller2');
    balances.set('buyer1', 1000);
    expect(purchaseAnalysisTime(id, 2, 'buyer1')).toBe(true);
    expect(balances.get('buyer1')).toBe(600);
    expect(balances.get('seller2')).toBe(400);
    const updatedListing = listings.get(id);
    expect(updatedListing.availability).toBe(498);
  });
  
  it('should allow removing a listing', () => {
    const id = createListing('Electron Microscope', 'High-powered electron microscope for nanoscale analysis', 300, 200, 'Astromaterials Research Lab, Japan', 'seller3');
    expect(removeListing(id, 'seller3')).toBe(true);
    expect(listings.has(id)).toBe(false);
  });
  
  it('should not allow purchasing with insufficient balance', () => {
    const id = createListing('Raman Spectrometer', 'Portable Raman spectrometer for in-situ analysis', 150, 300, 'Mobile Astrobiology Unit, Mars', 'seller4');
    balances.set('buyer2', 100);
    expect(() => purchaseAnalysisTime(id, 1, 'buyer2')).toThrow('Insufficient balance');
  });
  
  it('should not allow unauthorized listing removal', () => {
    const id = createListing('Gas Chromatograph', 'Advanced gas chromatograph for atmospheric analysis', 250, 400, 'Planetary Science Institute, Canada', 'seller5');
    expect(() => removeListing(id, 'unauthorized_user')).toThrow('Not authorized');
  });
});

