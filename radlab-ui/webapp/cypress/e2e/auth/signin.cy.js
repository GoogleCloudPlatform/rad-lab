/// <reference types="cypress" />

const UNAUTHORIZED_EMAIL = "foo@bar.com"
const INVALID_EMAIL = "bademail"

const CORRECT_PASSWORD = "password"
const WRONG_PASSWORD = "wrongpassword"
const SHORT_PASSWORD = "short"

describe("RAD Lab UI sign in", () => {
  beforeEach(() => {
    // Cypress starts out with a blank slate for each test
    // so we must tell it to visit our website with the `cy.visit()` command.
    // Since we want to visit the same URL at the start of all our tests,
    // we include it in our beforeEach function so that it runs before each test
    cy.visit("https://rad-lab-ui-d099.uc.r.appspot.com/signin/")
  })

  describe("field validation", () => {
    it("check email validation", () => {
      cy.get("#email").type(INVALID_EMAIL).blur()

      cy.get(".invalid-feedback").should(
        "have.text",
        "email must be a valid email",
      )
    })

    it("check password validation", () => {
      cy.get("#password").type(SHORT_PASSWORD).blur()

      cy.get(".invalid-feedback").should(
        "have.text",
        "Must be at least 8 characters",
      )
    })
  })

  it("links to forgot password", () => {
    cy.get("a").contains("Forgot password?").click()
    cy.url().should("include", "/password-reset")
  })

  it("fails with wrong password", () => {
    cy.get("#email").type(UNAUTHORIZED_EMAIL)
    cy.get("#password").type(WRONG_PASSWORD)

    cy.get("button.btn-primary").click()

    cy.get(".bg-error").should(
      "have.text",
      "Wrong user/password combination, or you previously used a different signin method.",
    )
  })

  it(
    "signs in with unauthorized user",
    { defaultCommandTimeout: 10000 },
    () => {
      cy.get("#email").type(UNAUTHORIZED_EMAIL)
      cy.get("#password").type(CORRECT_PASSWORD)

      cy.get("button.btn-primary").click()

      cy.get("#__next").should(
        "contain",
        "You are not authorized to use this part of the application",
      )

      const signoutBtn = cy.get("button.btn-primary")
      signoutBtn.should("have.text", "Sign Out")
      signoutBtn.click()

      cy.get("#__next").should("contain", "Sign in with email and password")
    },
  )

  // TODO: Sign in with Google
  // https://docs.cypress.io/guides/end-to-end-testing/google-authentication#Custom-Command-for-Google-Authentication
})
