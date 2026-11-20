/**
 * Strategy Pattern - Khớp với PricingStrategy trong Class Diagram
 */
export interface PricingStrategy {
  computePrice(baseAmount: number, startTime: Date, endTime: Date): number;
}

export class StandardPricingStrategy implements PricingStrategy {
  computePrice(baseAmount: number, startTime: Date, endTime: Date): number {
    const hours = Math.max(
      1,
      (endTime.getTime() - startTime.getTime()) / (1000 * 60 * 60)
    );
    return Math.round(baseAmount * hours);
  }
}

export class DynamicAIPricingStrategy implements PricingStrategy {
  constructor(private readonly demandFactor: number = 1.15) {}

  computePrice(baseAmount: number, startTime: Date, endTime: Date): number {
    const hours = Math.max(
      1,
      (endTime.getTime() - startTime.getTime()) / (1000 * 60 * 60)
    );
    return Math.round(baseAmount * hours * this.demandFactor);
  }
}
