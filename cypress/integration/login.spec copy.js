describe(`login scenario using task`, () => {

    it(`login test`, () => {
        cy.login();
        cy.visit(`/home`);
        cy.get("[class='c-nav__profile__menu-arrow']").click();
        cy.get("[href='/auth/logout']").click()
        cy.get('[data-qa="googleButton"]').should('be.visible')
    })
});
