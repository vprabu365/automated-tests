describe(`login scenario using task`, () => {

    it(`login test`, () => {
        cy.login();
        cy.visit(`/home`);
    })
});
