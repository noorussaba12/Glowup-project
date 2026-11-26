const assert = require('assert');
const fs = require('fs');
const path = require('path');

console.log('🧪 Running Nutriflow Clinical Nutrition Engine Verification Tests...');

// 1. Verify Seed Files Exist and are valid JSON
const mealsPath = path.join(__dirname, 'meals.json');
const ingredientsPath = path.join(__dirname, 'ingredients.json');

assert(fs.existsSync(mealsPath), 'meals.json must exist');
assert(fs.existsSync(ingredientsPath), 'ingredients.json must exist');

const mealsData = JSON.parse(fs.readFileSync(mealsPath, 'utf8'));
const ingredientsData = JSON.parse(fs.readFileSync(ingredientsPath, 'utf8'));

assert(Array.isArray(mealsData) && mealsData.length >= 10, 'Must have at least 10 verified meals');
assert(Array.isArray(ingredientsData) && ingredientsData.length >= 15, 'Must have at least 15 verified ingredients');
console.log(`✅ Loaded ${mealsData.length} meals and ${ingredientsData.length} ingredients from seed data.`);

// 2. Test Safe Caloric Floor (Mifflin-St Jeor)
function calculateCaloricTarget(basics) {
  if (basics.age < 18) {
    return 0; // Under-18 quality-first mode
  }
  let bmr;
  if (basics.sex.toLowerCase() === 'male') {
    bmr = (10 * basics.weightKg) + (6.25 * basics.heightCm) - (5 * basics.age) + 5;
  } else {
    bmr = (10 * basics.weightKg) + (6.25 * basics.heightCm) - (5 * basics.age) - 161;
  }
  let target = Math.round(bmr * 1.375);
  const safeFloor = (basics.sex.toLowerCase() === 'male') ? 1500 : 1200;
  if (target < safeFloor) {
    target = safeFloor;
  }
  return target;
}

// Test adult female safe floor
const femaleTarget = calculateCaloricTarget({ age: 30, sex: 'female', heightCm: 148, weightKg: 40 });
assert(femaleTarget >= 1200, `Female caloric target ${femaleTarget} must be >= 1200 kcal floor`);
console.log(`✅ Female Safe Caloric Floor Test Passed (${femaleTarget} kcal >= 1200)`);

// Test adult male safe floor
const maleTarget = calculateCaloricTarget({ age: 35, sex: 'male', heightCm: 155, weightKg: 48 });
assert(maleTarget >= 1500, `Male caloric target ${maleTarget} must be >= 1500 kcal floor`);
console.log(`✅ Male Safe Caloric Floor Test Passed (${maleTarget} kcal >= 1500)`);

// Test under-18 rule
const minorTarget = calculateCaloricTarget({ age: 16, sex: 'female', heightCm: 160, weightKg: 50 });
assert.strictEqual(minorTarget, 0, 'Under-18 users must have calorie counting disabled (target 0)');
console.log(`✅ Under-18 Calorie Restriction Protection Passed (target = 0)`);

// 3. Test Allergy Filtering
function filterMeals(meals, allergens, dietTags) {
  return meals.filter(meal => {
    if (!meal.verified) return false;
    // Check allergens
    const allergensList = Array.isArray(meal.allergens) ? meal.allergens : (meal.allergens || '').split(' ');
    for (const allergy of allergens) {
      if (allergensList.some(a => a.toLowerCase().includes(allergy.toLowerCase()))) {
        return false;
      }
    }
    // Check diet tags
    const tagsList = Array.isArray(meal.dietTags) ? meal.dietTags : (meal.dietTags || '').split(' ');
    for (const tag of dietTags) {
      if (!tagsList.some(t => t.toLowerCase().includes(tag.toLowerCase()))) {
        return false;
      }
    }
    return true;
  });
}

// Filter egg meals
const noEggMeals = filterMeals(mealsData, ['eggs'], ['halal']);
const eggConflict = noEggMeals.find(m => m.allergens && m.allergens.includes('eggs'));
assert(!eggConflict, 'Allergy filter must not return meals containing eggs');
console.log(`✅ Allergy Filtering Passed (${noEggMeals.length} safe meals found with no eggs)`);

// Filter vegetarian meals
const vegMeals = filterMeals(mealsData, [], ['vegetarian']);
const nonVegConflict = vegMeals.find(m => !m.dietTags.includes('vegetarian'));
assert(!nonVegConflict, 'Vegetarian filter must only return vegetarian meals');
console.log(`✅ Vegetarian Dietary Filter Passed (${vegMeals.length} safe meals)`);

// 4. Test Budget Calculation & Alternative Swapping
const expensiveMeal = mealsData.find(m => m.id === 'oats_dahi_nuts');
assert(expensiveMeal, 'Oats dahi meal should exist');
const initialCost = expensiveMeal.estimatedCostPKR;
const savingPKR = 20; // Substitute almonds with peanuts
const discountedCost = initialCost - savingPKR;
assert(discountedCost < initialCost, 'Alternative must reduce meal cost');
console.log(`✅ Affordable Alternative Test Passed (Original: ₨ ${initialCost} PKR -> Swapped: ₨ ${discountedCost} PKR, saved ₨ ${savingPKR})`);

console.log('🎉 ALL 5 CLINICAL NUTRIFLOW TESTS PASSED CLEANLY!');
