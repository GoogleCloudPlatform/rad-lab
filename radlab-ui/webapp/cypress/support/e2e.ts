import "./commands"

// https://docs.cypress.io/api/events/catalog-of-events#Uncaught-Exceptions
Cypress.on("uncaught:exception", (_err, _runnable) => {
  // returning false here prevents Cypress from
  // failing the test
  return false
})
