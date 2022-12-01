import dotenv from 'dotenv'

// Environment variables
dotenv.config({
  path: '.env.local',
})

// Mocks
jest.mock('next/router', () => require('next-router-mock'))
jest.mock('react-i18next', () => ({
  // this mock makes sure any components using the translate hook can use it without a warning being shown
  useTranslation: () => ({
    t: (str: string): string => str,
  }),
}))
