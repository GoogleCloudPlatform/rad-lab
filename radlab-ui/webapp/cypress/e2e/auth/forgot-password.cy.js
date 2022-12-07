/// <reference types="cypress" />

const INVALID_EMAIL = "bademail"
const FORGOT_EMAIL = "foo@example.com"

describe("RAD Lab UI sign in", () => {
  beforeEach(() => {
    // Cypress starts out with a blank slate for each test
    // so we must tell it to visit our website with the `cy.visit()` command.
    // Since we want to visit the same URL at the start of all our tests,
    // we include it in our beforeEach function so that it runs before each test
    cy.visit("https://rad-lab-ui-d099.uc.r.appspot.com/password-reset/")
  })

  it("loads the page", () => {
    cy.get(".text-xl").should("have.text", "Reset your password")
  })

  describe("validation", () => {
    it("checks email format", () => {
      cy.get("#email").type(INVALID_EMAIL).blur()

      cy.get(".invalid-feedback").should(
        "have.text",
        "email must be a valid email",
      )
    })

    it("checks email is required", () => {
      cy.get("#email").focus().blur()
      cy.get(".invalid-feedback").should("have.text", "Email is required")
    })
  })

  it("links back to signin", () => {
    cy.get("a").contains("Back to signin page").click()
    cy.url().should("include", "/signin")
  })

  it("sends password reset email", () => {
    cy.get("#email").type(FORGOT_EMAIL)
    cy.get("button.btn-primary").click()

    cy.get(".alert").should(
      "have.text",
      "A password reset email has been sent!",
    )
  })
})
